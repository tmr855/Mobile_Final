<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Order extends Model
{
    use HasFactory;

    protected $fillable = [
        'customer_name',
        'customer_email',
        'total',
    ];

    // Relationship: an order has many order items
    public function items()
    {
        return $this->hasMany(OrderItem::class);
    }
}
